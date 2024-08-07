import styles from './title.module.css';

const Title = ({ title, sub }) => (
  <div className={ styles.title } >
    <h4 className='cap-first'>{ title }</h4>
    <span>{ sub }</span>
  </div>
);

Title.displayName = 'Title';

export default Title;
