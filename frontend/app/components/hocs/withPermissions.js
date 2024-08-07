import React from 'react';
import { connect } from 'react-redux';
import { NoPermission, NoSessionPermission } from 'UI';

export default (requiredPermissions, className, isReplay = false, andEd = true) => (BaseComponent) => {
  @connect((state, props) => ({
    permissions:
      state.getIn(['user', 'account', 'permissions']) || [],
    isEnterprise:
      state.getIn(['user', 'account', 'edition']) === 'ee'
  }))
  class WrapperClass extends React.PureComponent {
    render() {
      const hasPermission = andEd ?
        requiredPermissions.every((permission) => this.props.permissions.includes(permission)) :
        requiredPermissions.some((permission) => this.props.permissions.includes(permission)
        );

      return !this.props.isEnterprise || hasPermission ? (
        <BaseComponent {...this.props} />
      ) : (
        <div className={className}>
          {isReplay ? (
            <NoSessionPermission />
          ) : (
            <NoPermission />
          )}
        </div>
      );
    }
  }

  return WrapperClass;
}
